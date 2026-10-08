using UnityEngine;
using Kamilunavo.RepairEmpire.Input;

namespace Kamilunavo.RepairEmpire.Gameplay
{
    [RequireComponent(typeof(Rigidbody))]
    public sealed class VehicleController : MonoBehaviour
    {
        public HoldButton Left;
        public HoldButton Right;
        public HoldButton Accelerate;
        public HoldButton Brake;
        public bool InputEnabled = true;

        public float Acceleration = 18f;
        public float BrakeForce = 24f;
        public float Steering = 72f;
        public float MaxSpeed = 22f;

        private Rigidbody _body;

        public float SpeedKmh
        {
            get
            {
                var v = _body.linearVelocity;
                return new Vector3(v.x, 0f, v.z).magnitude * 3.6f;
            }
        }

        private void Awake()
        {
            _body = GetComponent<Rigidbody>();
            _body.centerOfMass = new Vector3(0f, -0.45f, 0f);
        }

        private void FixedUpdate()
        {
            if (!InputEnabled)
            {
                ResetMotion();
                return;
            }

            var steer = (Right != null && Right.Held ? 1f : 0f) - (Left != null && Left.Held ? 1f : 0f);
            steer += UnityEngine.Input.GetAxisRaw("Horizontal");
            steer = Mathf.Clamp(steer, -1f, 1f);

            var gas = (Accelerate != null && Accelerate.Held ? 1f : 0f) + (UnityEngine.Input.GetKey(KeyCode.W) ? 1f : 0f);
            var braking = (Brake != null && Brake.Held ? 1f : 0f) + (UnityEngine.Input.GetKey(KeyCode.S) ? 1f : 0f);

            var forwardSpeed = Vector3.Dot(_body.linearVelocity, transform.forward);
            if (gas > 0f && forwardSpeed < MaxSpeed)
                _body.AddForce(transform.forward * (Acceleration * gas), ForceMode.Acceleration);

            if (braking > 0f)
                _body.AddForce(-transform.forward * (BrakeForce * braking), ForceMode.Acceleration);

            var speedFactor = Mathf.Clamp01(Mathf.Abs(forwardSpeed) / 4f);
            var turn = steer * Steering * (0.30f + 0.70f * speedFactor) * Time.fixedDeltaTime;
            _body.MoveRotation(_body.rotation * Quaternion.Euler(0f, turn, 0f));

            var local = transform.InverseTransformDirection(_body.linearVelocity);
            local.x *= 0.82f;
            local.z = Mathf.Clamp(local.z, -8f, MaxSpeed);
            _body.linearVelocity = transform.TransformDirection(local);
        }

        private void Damp(float amount)
        {
            var v = _body.linearVelocity;
            _body.linearVelocity = new Vector3(v.x * amount, v.y, v.z * amount);
        }

        public void SetInputEnabled(bool enabled)
        {
            InputEnabled = enabled;
            if (!enabled) ResetMotion();
        }

        public void ResetMotion()
        {
            Left?.ResetInput(); Right?.ResetInput(); Accelerate?.ResetInput(); Brake?.ResetInput();
            _body.linearVelocity = Vector3.zero;
            _body.angularVelocity = Vector3.zero;
        }
    }
}
