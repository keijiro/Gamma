using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.VFX;

namespace Gamma {

public sealed class ThrottleInputHandler : MonoBehaviour
{
    [field:SerializeField] VisualEffect Target = null;
    [field:SerializeField] InputAction Action = null;

    bool _active;

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
    {
        _active = !_active;
        Target.SetFloat("Throttle", _active ? 1 : 0);
    }
}

} // namespace Gamma
