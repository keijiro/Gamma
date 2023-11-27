using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;

namespace Gamma {

public sealed class InputActionHandler : MonoBehaviour
{
    [field:Space]
    [field:SerializeField] InputAction Action = null;

    [field:Space]
    [field:SerializeField] UnityEvent Event = null;

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
      => Event.Invoke();
}

} // namespace Gamma
