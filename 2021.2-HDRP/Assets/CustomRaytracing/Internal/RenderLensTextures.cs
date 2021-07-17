using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteAlways]
public class RenderLensTextures : MonoBehaviour
{
    public CustomRTPass _camera;
    public RenderTexture lensPositionTex, lensDirectionTex;
    public Shader lensShader;

    public enum Channel
    {
        UV,
        UV2
    }

    public Channel channel = Channel.UV;
    
    private Material lensMaterial;
    private RenderBuffer[] _mrt;

    public Transform rendererRoot;
    private List<Renderer> renderers;

    private void OnEnable()
    {
        lensPositionTex = new RenderTexture(_camera.textureWidth, _camera.textureHeight, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
        lensDirectionTex = new RenderTexture(lensPositionTex);
        lensPositionTex.hideFlags = HideFlags.DontSave;
        lensDirectionTex.hideFlags = HideFlags.DontSave;

        lensMaterial = new Material(lensShader);
        lensMaterial.hideFlags = HideFlags.DontSave;
        
        _mrt = new RenderBuffer[2];

        renderers = rendererRoot.GetComponentsInChildren<Renderer>().ToList();
    }

    private void OnDisable()
    {
        lensPositionTex.Release();
        lensDirectionTex.Release();
        
        if(Application.isPlaying)
            Destroy(lensMaterial);
        else
            DestroyImmediate(lensMaterial);
    }

    [ContextMenu("Render Now")]
    public void RenderLensTexturesNow()
    {
        // clear both targets
        RenderTexture.active = lensPositionTex;
        GL.Clear(true, true, Color.clear, 0);
        RenderTexture.active = lensDirectionTex;
        GL.Clear(true, true, Color.clear, 0);
        
        // set MRT
        
        _mrt[0] = lensPositionTex.colorBuffer;
        _mrt[1] = lensDirectionTex.colorBuffer;

        // Blit with a MRT.
        Graphics.SetRenderTarget(_mrt, lensPositionTex.depthBuffer);

        lensMaterial.SetPass(0);
        lensMaterial.DisableKeyword("_TARGET_CHANNEL_UV");
        lensMaterial.DisableKeyword("_TARGET_CHANNEL_UV2");
        if (channel == Channel.UV)
            lensMaterial.EnableKeyword("_TARGET_CHANNEL_UV");
        else
            lensMaterial.EnableKeyword("_TARGET_CHANNEL_UV2");
        
        // render mesh(es) into MRT via lensShader that essentially performs UV-space rendering
        foreach (var r in renderers)
        {
            var meshFilter = r.GetComponent<MeshFilter>();
            var mesh = meshFilter.sharedMesh;
            var mats = r.sharedMaterials;
            
            for(int i = 0; i < mesh.subMeshCount; i++)
            {
                var currentMat = mats[i % mats.Length];
                
                lensMaterial.mainTexture = currentMat.mainTexture;
                lensMaterial.mainTextureOffset = currentMat.mainTextureOffset;
                lensMaterial.mainTextureScale = currentMat.mainTextureScale;
                
                Graphics.DrawMeshNow(mesh, Vector3.zero, Quaternion.identity, i);
            }
        }

        Graphics.SetRenderTarget(null);
        RenderTexture.active = null;
    }
}
