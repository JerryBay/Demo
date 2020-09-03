using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AutoNavi : MonoBehaviour
{
    private NavMeshAgent _navMeshAgent;
    private Animator _animator;
    private Vector3 _destination;
    private void ToDestination(Vector3 dest)
    {
        _destination=dest;
        _navMeshAgent.SetDestination(dest);
    }
    void Awake()
    {
        _navMeshAgent=GetComponent<NavMeshAgent>();
        _animator=GetComponent<Animator>();
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
                    _destination=hit.point;
                    _navMeshAgent.SetDestination(_destination);
                }
            }
        }
    }
    void FixedUpdate() {
        if(_navMeshAgent.velocity.magnitude>0.01f)
        {
            _animator.SetFloat("Speed",0.2f);
        }
        if(_navMeshAgent.velocity.magnitude<0.1f||Vector3.Distance(_destination,transform.position)<0.4f)
        {
            _navMeshAgent.velocity=Vector3.zero;
            _animator.SetFloat("Speed",0);
        }
    }
}
