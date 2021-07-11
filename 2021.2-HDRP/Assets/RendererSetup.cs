using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

public class RendererSetup : MonoBehaviour
{
    [ContextMenu("Show Render Mode")]
    void LogRenderMode()
    {
        Debug.Log(GetComponent<Renderer>().rayTracingMode);
    }

    [ContextMenu("Set Render Mode Dynamic")]
    void SetMode()
    {
        GetComponent<Renderer>().rayTracingMode = RayTracingMode.DynamicGeometry;
    }
    
    [ContextMenu("Set Render Mode Off")]
    void SetModeOff()
    {
        GetComponent<Renderer>().rayTracingMode = RayTracingMode.Off;
    }
}
