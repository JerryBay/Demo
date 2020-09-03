using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    private Animator _animator;
    public float _speed=1;
    void Start()
    {
        _animator=GetComponent<Animator>();
    }
    private void Move(Vector3 destPos)
    {
        StopAllCoroutines();
        StartCoroutine(IMove(destPos));
    }
    private IEnumerator IMove(Vector3 destPos)
    {
        while(Vector3.Distance(destPos,transform.position)>0.001)
        {
            Vector3 dir=Vector3.Normalize(destPos-transform.position);
            transform.Translate(dir*_speed*Time.deltaTime);
            yield return null;
        }
        transform.position=destPos;
        //yield break;
    }
    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
            Ray ray=Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if(Physics.Raycast(ray,out hit))
            {
                if(hit.collider.name=="Plane")
                {
                    Vector3 pos=hit.point;
                    pos+=Vector3.up*0.5f;
                    Move(pos);
                }
            }
        }
        // float vertical=Input.GetAxis("Vertical");
        // float horizontal=Input.GetAxis("Horizontal");
        // Vector3 dir=new Vector3(horizontal,0,vertical);
        // if(dir!=Vector3.zero)
        // {
        //     _animator.SetBool("Run",true);
        //     transform.Translate(dir*_speed*Time.deltaTime);
        // }
        // else
        // {
        //     _animator.SetBool("Run",false);
        // }
    }
}
