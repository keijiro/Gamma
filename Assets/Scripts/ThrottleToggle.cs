using UnityEngine;
using UnityEngine.VFX;
using Klak.Math;

namespace Gamma {

public sealed class ThrottleToggle : MonoBehaviour
{
    [field:SerializeField] VisualEffect Target = null;
    [field:SerializeField] float Speed = 0.5f;

    bool _active;
    float _param;

    public void Toggle()
      => _active = !_active;

    void Update()
    {
        _param = ExpTween.Step(_param, _active ? 1 : 0, Speed);
        Target.SetFloat("Throttle", _param);
    }
}

} // namespace Gamma
