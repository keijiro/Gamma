using UnityEngine;
using UnityEngine.UI;
using OscJack;

public sealed class MessageSender : MonoBehaviour
{
    [field:SerializeField] InputField AddressField = null;

    const string AddressKey = "TargetAddress";
    const int PortNumber = 8000;

    (OscClient osc, string address) _client;

    void PrepareClient()
    {
        var address = AddressField.text;
        if (_client.address == address) return;

        _client.osc = new OscClient(address, PortNumber);
        _client.address = address;

        PlayerPrefs.SetString(AddressKey, address);
    }


    public void Start()
      => AddressField.text = PlayerPrefs.GetString(AddressKey, "192.168.0.1");

    public void Send(string path)
    {
        PrepareClient();
        _client.osc.Send(path);
    }
}
