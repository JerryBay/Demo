using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimatorController : MonoBehaviour
{
    private Animator _anim;

    private void Awake()
    {
        _anim = GetComponent<Animator>();
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.Q))
        {
            _anim.SetInteger(Animator.StringToHash("Gesture"), 1);
        }
        if (Input.GetKeyDown(KeyCode.W))
        {
            _anim.SetInteger(Animator.StringToHash("Gesture"), 2);
        }
        if (Input.GetKeyDown(KeyCode.E))
        {
            _anim.SetInteger(Animator.StringToHash("Gesture"), 3);
        }
    }
}
