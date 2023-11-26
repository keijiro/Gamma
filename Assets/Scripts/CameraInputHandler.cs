using Unity.Mathematics;
using UnityEngine;
using UnityEngine.InputSystem;
using Klak.Math;
using Klak.Motion;

namespace Gamma {

public sealed class CameraInputHandler : MonoBehaviour
{
    [field:Space]
    [field:SerializeField] Camera Camera = null;
    [field:SerializeField] float Fov0 = 13;
    [field:SerializeField] float Fov1 = 90;

    [field:Space]
    [field:SerializeField] BrownianMotion Motion = null;
    [field:SerializeField] float Displacement0 = 3;
    [field:SerializeField] float Displacement1 = 0.5f;

    [field:Space]
    [field:SerializeField] BrownianMotion Rotation = null;
    [field:SerializeField] float Angle0 = 120;
    [field:SerializeField] float Angle1 = 30;

    [field:Space]
    [field:SerializeField] float Speed = 0.5f;

    [field:Space]
    [field:SerializeField] InputAction Action = null;

    bool _active;
    float _param;

    void OnEnable()
    {
        Action.performed += OnPerformed;
        Action.Enable();
    }

    void OnDisable()
    {
        Action.Disable();
        Action.performed -= OnPerformed;
    }

    void OnPerformed(InputAction.CallbackContext ctx)
      => _active = !_active;

    void Update()
    {
        _param = ExpTween.Step(_param, _active ? 1 : 0, Speed);

        Camera.fieldOfView = Mathf.Lerp(Fov0, Fov1, _param);

        var d = math.lerp(Displacement0, Displacement1, _param);
        Motion.positionAmount = math.float3(0, 0, d);

        var a = math.lerp(Angle0, Angle1, _param);
        Rotation.rotationAmount = math.float3(a, a, a);
    }
}

} // namespace Gamma
