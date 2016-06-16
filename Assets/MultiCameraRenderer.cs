using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class MultiCameraRenderer : MonoBehaviour
{
    public Camera[] SourceCameras;
    public bool OverrideRenderCameraSettings = true;
    public bool DelayCameraDeactivate = true;
    public bool PassThroughShadowMap = true;

    public Light LightSources;
    public Shader ReplacementShader;

    [Header("Output settings")]
    public BuiltinRenderTextureType TargetTexture = BuiltinRenderTextureType.CurrentActive;
    public CameraEvent CameraEvent = CameraEvent.AfterGBuffer;
    public bool UpdateSettings = false;

    private Camera _renderCamera;
    private RenderTexture _renderTexture;
    private CommandBuffer _copyShadowMap;

    private const string GlobalShadowmapName = "_GlobalShadowMap";

    private void Awake()
    {
        _renderCamera = GetComponent<Camera>();

        if (OverrideRenderCameraSettings)
        {
            _renderCamera.cullingMask = 0;
            _renderCamera.clearFlags = CameraClearFlags.Nothing;
            _renderCamera.useOcclusionCulling = false;
            _renderCamera.hdr = false;
        }

        if (PassThroughShadowMap && SourceCameras.Length > 1)
        {
            AddCommandBufferToSourceCamera();

            SetReplacementShaderOnDestinationCameras();
        }
    }

    private void Start()
    {
        StartCoroutine(DeactivateCameras());
        InvokeRepeating("CheckForRefresh", 1f, 1f);
    }

    private void OnPreRender()
    {
        _renderTexture = RenderTexture.GetTemporary(_renderCamera.pixelWidth, _renderCamera.pixelHeight, 24, RenderTextureFormat.ARGBFloat);

        for (var i = 0; i < SourceCameras.Length; i++)
        {
            var c = SourceCameras[i];
            c.targetTexture = _renderTexture;
            c.Render();
            c.targetTexture = null;
        }
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(_renderTexture, dest);
        RenderTexture.ReleaseTemporary(_renderTexture);
    }

    private IEnumerator DeactivateCameras()
    {
        if (DelayCameraDeactivate)
        {
            yield return null;
        }

        for (var i = 0; i < SourceCameras.Length; i++)
        {
            SourceCameras[i].enabled = false;
        }
    }

    private void AddCommandBufferToSourceCamera()
    {
        Debug.Log("Updating command buffer");

        SourceCameras[0].RemoveAllCommandBuffers();

        _copyShadowMap = new CommandBuffer();
        _copyShadowMap.name = "Copy shadow map";
        _copyShadowMap.SetGlobalTexture(GlobalShadowmapName, new RenderTargetIdentifier(TargetTexture));

        SourceCameras[0].AddCommandBuffer(CameraEvent, _copyShadowMap);

        Debug.Log("Command buffer update complete");
    }

    private void SetReplacementShaderOnDestinationCameras()
    {
        for (var i = 1; i < SourceCameras.Length; i++)
        {
            SourceCameras[i].SetReplacementShader(ReplacementShader, null);
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
