using UnityEngine;
using System.Linq;

public class ShadowCastToggler : MonoBehaviour
{
    private Renderer[] _renderers;

    private void OnEnable()
    {
        RefreshRenderers();
    }

    private void OnPreRender()
    {
        for (var i = 0; i < _renderers.Length; i++)
        {
            _renderers[i].shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly;
        }
    }

    public void OnPostRender()
    {
        for (var i = 0; i < _renderers.Length; i++)
        {
            _renderers[i].shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.On;
        }
    }

    private void RefreshRenderers()
    {
        var allRenderers = FindObjectsOfType<Renderer>();
        var childRenderers = GetComponentsInChildren<Renderer>();
        _renderers = allRenderers.Except(childRenderers).ToArray();
    }

}
