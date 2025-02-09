;; vehicle-registration.clar

;; Define data structures
(define-map vehicles
  { id: uint }
  {
    owner: principal,
    model: (string-ascii 64),
    license-plate: (string-ascii 20),
    status: (string-ascii 20),
    registration-date: uint
  }
)

(define-data-var next-vehicle-id uint u0)

;; Constants
(define-constant err-vehicle-exists u100)
(define-constant err-vehicle-not-found u101)
(define-constant err-unauthorized u102)

;; Functions
(define-public (register-vehicle (model (string-ascii 64)) (license-plate (string-ascii 20)))
  (let
    (
      (vehicle-id (var-get next-vehicle-id))
    )
    (asserts! (is-none (map-get? vehicles { id: vehicle-id })) (err err-vehicle-exists))
    (map-set vehicles
      { id: vehicle-id }
      {
        owner: tx-sender,
        model: model,
        license-plate: license-plate,
        status: "active",
        registration-date: block-height
      }
    )
    (var-set next-vehicle-id (+ vehicle-id u1))
    (ok vehicle-id)
  )
)

(define-public (update-vehicle-status (vehicle-id uint) (new-status (string-ascii 20)))
  (let
    (
      (vehicle (unwrap! (map-get? vehicles { id: vehicle-id }) (err err-vehicle-not-found)))
    )
    (asserts! (is-eq (get owner vehicle) tx-sender) (err err-unauthorized))
    (ok (map-set vehicles
      { id: vehicle-id }
      (merge vehicle { status: new-status })
    ))
  )
)

(define-read-only (get-vehicle (vehicle-id uint))
  (map-get? vehicles { id: vehicle-id })
)

(define-read-only (is-vehicle-active (vehicle-id uint))
  (match (map-get? vehicles { id: vehicle-id })
    vehicle (is-eq (get status vehicle) "active")
    false
  )
)

