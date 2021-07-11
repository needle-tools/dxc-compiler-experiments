using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

[ExecuteAlways]
public class BakeParticleMesh : MonoBehaviour
{
    public ParticleSystemRenderer target;
    private Mesh mesh;
    
    void Update()
    {
        if (!target) return;
        
        if (mesh == null)
            mesh = new Mesh();

        target.BakeMesh(mesh, Camera.main, true);
        GetComponent<MeshFilter>().sharedMesh = mesh;
        GetComponent<MeshRenderer>().rayTracingMode = RayTracingMode.DynamicGeometry;
    }
}
