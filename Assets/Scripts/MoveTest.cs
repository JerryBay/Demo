using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveTest : MonoBehaviour
{
    public MoveManager _movemanager;
    private void Update() 
    {
        if(Input.GetKeyDown(KeyCode.M))
        {           
            _movemanager=FindObjectOfType<MoveManager>();
            if(!_movemanager)
            {
                Debug.LogError("No Movemanager");
            }
            _movemanager.Move();
        }
    }
}
