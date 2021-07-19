using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;

public class FlyAroundFallback : MonoBehaviour
{
    public InputActionAsset map;
    public float movementSpeed = 150;
    public float rotationSpeed = 150;
    public bool HorizonLock = true;

    private InputAction translate, rotate;
    
    private void Start()
    {
        Debug.Log(string.Join("\n", map.bindings.Select(x => x.effectivePath.ToString())));
        
        translate = map["Fly/Translation"];//.performed += TranslationPerformed;
        rotate = map["Fly/Rotation"];//.performed += RotationPerformed;
    }

    private void OnEnable()
    {
        map.Enable();
    }

    private void OnDisable()
    {
        map.Disable();
    }

    private void Update()
    {
        TranslationPerformed();
        RotationPerformed();
    }

    private void TranslationPerformed()//InputAction.CallbackContext ctx)
    {
        var amount = translate.ReadValue<Vector3>();
        // Debug.Log("Translation: " + amount);
		
        transform.Translate(amount * movementSpeed * Time.deltaTime, Space.Self);
    }
	
    private void RotationPerformed()
    {
        var amount = rotate.ReadValue<Vector3>();
        // Debug.Log("Rotation: " + amount);
		
        if (HorizonLock)
        {
            transform.Rotate(Vector3.up, amount.y * rotationSpeed * Time.deltaTime, Space.World);
            transform.Rotate(Vector3.right, amount.x * rotationSpeed * Time.deltaTime, Space.Self);
        }
        else
        {
            transform.Rotate(amount * rotationSpeed * Time.deltaTime, Space.Self);
        }
    }
}
