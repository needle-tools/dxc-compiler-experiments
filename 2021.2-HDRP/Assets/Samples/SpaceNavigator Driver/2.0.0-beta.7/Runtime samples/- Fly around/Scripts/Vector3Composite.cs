using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Layouts;
using UnityEngine.InputSystem.Utilities;

#if UNITY_EDITOR
[InitializeOnLoad]
#endif
[DisplayStringFormat("{firstPart}+{secondPart}")]
public class Vector3Composite : InputBindingComposite<Vector3> 
{
    [InputControl(layout = "Button")]
    public int modifier;
    
    [InputControl(layout = "Button")]
    public int up, down, left, right, forward, back;

    [InputControl(layout = "Axis")]
    public int upDown, leftRight, forwardBack;
    
    public override Vector3 ReadValue(ref InputBindingCompositeContext context)
    {
        if (!context.ReadValueAsButton(modifier))
            return default;
        
        var upIsPressed = context.ReadValueAsButton(up);
        var downIsPressed = context.ReadValueAsButton(down);
        var leftIsPressed = context.ReadValueAsButton(left);
        var rightIsPressed = context.ReadValueAsButton(right);
        var forwardIsPressed = context.ReadValueAsButton(forward);
        var backIsPressed = context.ReadValueAsButton(back);

        var upDownExtra = context.ReadValue<float>(upDown);
        var leftRightExtra = context.ReadValue<float>(leftRight);
        var forwardBackExtra = context.ReadValue<float>(forwardBack);

        var upValue = upIsPressed ? 1.0f : 0.0f;
        var downValue = downIsPressed ? -1.0f : 0.0f;
        var leftValue = leftIsPressed ? -1.0f : 0.0f;
        var rightValue = rightIsPressed ? 1.0f : 0.0f;
        var forwardValue = forwardIsPressed ? -1.0f : 0.0f;
        var backValue = backIsPressed ? 1.0f : 0.0f;

        var result = new Vector3(
            leftValue + rightValue + leftRightExtra, 
            upValue + downValue + upDownExtra, 
            forwardValue + backValue + forwardBackExtra);
        return result;
    }

    // This method computes the current actuation of the binding as a whole.
    public override float EvaluateMagnitude(ref InputBindingCompositeContext context)
    {
        return ReadValue(ref context).magnitude;
    }

    static Vector3Composite()
    {
        InputSystem.RegisterBindingComposite<Vector3Composite>();
    }

    [RuntimeInitializeOnLoadMethod]
    static void Init() {} // Trigger static constructor.
}
