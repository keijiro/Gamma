using UnityEngine;
using UnityEngine.InputSystem;
using BurstWig;

namespace Gamma {

public sealed class WigInputHandler : MonoBehaviour
{
    [field:SerializeField] WigController Target = null;
    [field:SerializeField] float Length0 = 0;
    [field:SerializeField] float Length1 = 1;
    [field:SerializeField] float Speed = 0.5f;
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
        var speed = Speed * (_active ? 1 : -1);
        _param = Mathf.Clamp01(_param + speed * Time.deltaTime);
        Target.Length = Mathf.Lerp(Length0, Length1, _param);
    }
}

} // namespace Gamma
