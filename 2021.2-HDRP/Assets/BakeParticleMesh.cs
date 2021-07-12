using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

[ExecuteAlways]
public class BakeParticleMesh : MonoBehaviour
{
    public ParticleSystemRenderer target;
    
    private static readonly Dictionary<ParticleSystemRenderer, (int lastFrame, Mesh cachedMesh)> cache = new Dictionary<ParticleSystemRenderer, (int, Mesh)>();
    // private Mesh mesh;

    private int lastFrame = -1;

    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;

    private void OnEnable()
    {
        cache.Clear();
    }

    void Update()
    {
        if (!target) return;

        if (!cache.ContainsKey(target))
        {
            var mesh = new Mesh {hideFlags = HideFlags.DontSave};
            cache.Add(target, (-1, mesh));
        }
        
        if(cache.TryGetValue(target, out var thing))
        {
            if (thing.lastFrame < Time.renderedFrameCount)
            {
                var mesh = thing.cachedMesh;
                target.BakeMesh(mesh, Camera.main, true);
                thing.lastFrame = Time.renderedFrameCount;
                thing.cachedMesh = mesh;
                cache[target] = thing;
            }
            
            if(!meshFilter) meshFilter = GetComponent<MeshFilter>();
            if(!meshRenderer) meshRenderer = GetComponent<MeshRenderer>();
            
            meshFilter.sharedMesh = thing.cachedMesh;
            meshRenderer.rayTracingMode = RayTracingMode.DynamicGeometry;
        }
        else
        {
            Debug.LogWarning("Target not in cache", target);
        }
    }
}
