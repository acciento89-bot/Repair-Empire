using UnityEngine;

namespace Kamilunavo.RepairEmpire.CameraSystem
{
    public sealed class VehicleCamera : MonoBehaviour
    {
        public Transform Target;
        public float Distance = 8.5f;
        public float Height = 4.2f;
        public float Smooth = 10f;

        private void LateUpdate()
        {
            if (Target == null) return;
            var desired = Target.position - Target.forward * Distance + Vector3.up * Height;
            transform.position = Vector3.Lerp(transform.position, desired, 1f - Mathf.Exp(-Smooth * Time.deltaTime));
            var focus = Target.position + Target.forward * 4f + Vector3.up * 1.5f;
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(focus - transform.position), 1f - Mathf.Exp(-Smooth * Time.deltaTime));
        }
    }
}
