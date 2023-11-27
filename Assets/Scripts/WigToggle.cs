using UnityEngine;
using BurstWig;
using Klak.Math;

namespace Gamma {

public sealed class WigToggle : MonoBehaviour
{
    [field:SerializeField] WigController Target = null;
    [field:SerializeField] float Length0 = 0;
    [field:SerializeField] float Length1 = 1;
    [field:SerializeField] float Speed = 0.5f;

    bool _active;
    float _param;

    public void Toggle()
      => _active = !_active;

    void Update()
    {
        _param = ExpTween.Step(_param, _active ? 1 : 0, Speed);
        Target.Length = Mathf.Lerp(Length0, Length1, _param);
    }
}

} // namespace Gamma
