using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveManager : MonoBehaviour
{
    [SerializeField] private Animator _animator;
    private Vector3 _originPosition;
    private Vector3 _originEulerAngles;
    private bool _isMoving = false;

    [System.Serializable]
    public struct DestPoint
    {
        public Vector3 destPosition;
        public Vector3 destEulerAngle;
    }
    public DestPoint _destination;

    public float _rotateDuration = 1.0f;
    public float _moveDuration = 3.0f;

    private void Awake()
    {
        _animator = GetComponent<Animator>();
        _originPosition = transform.localPosition;
        _originEulerAngles = transform.localEulerAngles;
    }

    public void Move()
    {
        if (_isMoving)
        {
            return;
        }
        StopAllCoroutines();
        StartCoroutine(MoveCoroutine());
    }

    private IEnumerator MoveCoroutine()
    {
        _isMoving = true;
        float timer = 0;

        Vector3 totalDistance = _destination.destPosition - transform.localPosition;
        Vector3 dirSpeed = totalDistance / _moveDuration;


        Vector3 lookAngle = Quaternion.LookRotation(totalDistance).eulerAngles;
        Vector3 firstRotationAngle = lookAngle - transform.eulerAngles;
        Vector3 firstRotationSpeed = firstRotationAngle / _rotateDuration;
        while (timer<_rotateDuration)
        {
            timer += Time.deltaTime;
            transform.localEulerAngles += firstRotationSpeed * Time.deltaTime;
            yield return null;
        }

        timer = 0;
        while (timer < _moveDuration)
        {
            timer += Time.deltaTime;
            transform.localPosition += dirSpeed * Time.deltaTime;
            yield return null;
        }
        transform.localPosition = _destination.destPosition;


        Vector3 secondRotationAngle = _destination.destEulerAngle - transform.localEulerAngles;
        Vector3 secondRotationSpeed = secondRotationAngle / _rotateDuration;

        timer = 0;
        while (timer < _rotateDuration)
        {
            timer += Time.deltaTime;
            transform.localEulerAngles += secondRotationSpeed * Time.deltaTime;
            yield return null;
        }

        _isMoving = false;
    }
}
