using UnityEngine;
using UnityEngine.Rendering;
using Klak.Math;

namespace Gamma {

public sealed class LightToggle : MonoBehaviour
{
    [field:Space]
    [field:SerializeField] MeshRenderer Renderer = null;
    [field:SerializeField] float Emission0 = 10;
    [field:SerializeField] float Emission1 = 80;

    [field:Space]
    [field:SerializeField] Volume Volume = null;

    [field:Space]
    [field:SerializeField] float Speed = 0.5f;

    int _state;
    float _param;
    MaterialPropertyBlock _prop;

    public void Toggle()
      => _state = (_state + 1) % 3;

    void Start()
      => _prop = new MaterialPropertyBlock();

    void Update()
    {
        _param = ExpTween.Step(_param, _state / 2.0f, Speed);

        _prop.SetFloat("_Emission", Mathf.Lerp(Emission0, Emission1, _param));
        Renderer.SetPropertyBlock(_prop);

        Volume.weight = _param;
    }
}

} // namespace Gamma
