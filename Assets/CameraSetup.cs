using UnityEngine;
using UnityEngine.Rendering;

public class CameraSetup : MonoBehaviour
{
    public bool PassThroughShadowMap = true;

    public Camera SourceCamera;
    public Camera[] DestinationCameras;
    public Shader ReplacementShader;

    [Header("Output settings")]
    public BuiltinRenderTextureType TargetTexture = BuiltinRenderTextureType.CurrentActive;
    public CameraEvent CameraEvent = CameraEvent.AfterGBuffer;
    public bool UpdateSettings = false;

    private CommandBuffer _copyShadowMap;
    private const string GlobalShadowmapName = "_GlobalShadowMap";

    private void Awake()
    {
        if (PassThroughShadowMap)
        {
            AddCommandBufferToSourceCamera();

            SetReplacementShaderOnDestinationCameras();
        }
    }

    private void Start()
    {
        InvokeRepeating("CheckForRefresh", 1f, 1f);
    }

    private void AddCommandBufferToSourceCamera()
    {
        Debug.Log("Updating command buffer");

        //SourceCameras[0].depthTextureMode = DepthTextureMode.DepthNormals;
        SourceCamera.RemoveAllCommandBuffers();

        _copyShadowMap = new CommandBuffer();
        _copyShadowMap.name = "Copy shadow map";
        _copyShadowMap.SetGlobalTexture(GlobalShadowmapName, new RenderTargetIdentifier(TargetTexture));

        SourceCamera.AddCommandBuffer(CameraEvent, _copyShadowMap);

        Debug.Log("Command buffer update complete");
    }

    private void SetReplacementShaderOnDestinationCameras()
    {
        for (var i = 0; i < DestinationCameras.Length; i++)
        {
            //SourceCameras[0].depthTextureMode = DepthTextureMode.None;
            DestinationCameras[i].SetReplacementShader(ReplacementShader, null);
        }
    }

    private void CheckForRefresh()
    {
        if (UpdateSettings)
        {
            UpdateSettings = false;
            AddCommandBufferToSourceCamera();
        }
    }
}
