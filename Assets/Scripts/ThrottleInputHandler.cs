using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.VFX;
using Klak.Math;

namespace Gamma {

public sealed class ThrottleInputHandler : MonoBehaviour
{
    [field:Space]
    [field:SerializeField] VisualEffect Target = null;
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
        Target.SetFloat("Throttle", _param);
    }
}

} // namespace Gamma
