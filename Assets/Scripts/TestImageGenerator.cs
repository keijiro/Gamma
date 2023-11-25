using UnityEngine;

namespace Gamma {

[ExecuteInEditMode]
public sealed class TestImageGenerator : MonoBehaviour
{
    [field:SerializeField] Material Material = null;
    [field:SerializeField] RenderTexture Destination = null;

    void Update()
    {
        if (Material != null && Destination != null)
            Graphics.Blit(null, Destination, Material);
    }
}

} // namespace Gamma
