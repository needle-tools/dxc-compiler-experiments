using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(RenderLensTextures))]
public class RenderLensTexturesEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        var t = target as RenderLensTextures;
        
        EditorGUILayout.Space();
        if (GUILayout.Button("Render Now"))
        {
            t.RenderLensTexturesNow();
        }

        EditorGUILayout.Space();
        var rect = GUILayoutUtility.GetAspectRect(t.lensPositionTex.width / (float) t.lensPositionTex.height);
        GUI.DrawTexture(rect, t.lensPositionTex, ScaleMode.ScaleToFit);
        EditorGUILayout.Space();
        rect = GUILayoutUtility.GetAspectRect(t.lensPositionTex.width / (float) t.lensPositionTex.height);
        GUI.DrawTexture(rect, t.lensDirectionTex, ScaleMode.ScaleToFit);
    }
}
