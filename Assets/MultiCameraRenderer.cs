using System.Collections;
using UnityEngine;
using UnityEngine.Rendering;

[RequireComponent(typeof(Camera))]
public class MultiCameraRenderer : MonoBehaviour
{
    public Camera[] SourceCameras;
    public bool OverrideRenderCameraSettings = true;
    public bool DelayCameraDeactivate = true;

    public Light LightSources;

    private Camera _renderCamera;
    private RenderTexture _renderTexture;
    
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
    }

    private void Start()
    {
        StartCoroutine(DeactivateCameras());
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
}
