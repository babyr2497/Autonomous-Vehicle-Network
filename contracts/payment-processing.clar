;; payment-processing.clar

;; Define data structures
(define-map payments
  { ride-id: uint }
  {
    passenger: principal,
    vehicle-id: uint,
    amount: uint,
    status: (string-ascii 20)
  }
)

(define-map balances
  { address: principal }
  { balance: uint }
)

;; Constants
(define-constant err-insufficient-balance u300)
(define-constant err-unauthorized u301)
(define-constant err-payment-not-found u302)

;; Functions
(define-public (process-payment (ride-id uint) (vehicle-id uint) (amount uint))
  (let
    (
      (passenger tx-sender)
      (passenger-balance (default-to { balance: u0 } (map-get? balances { address: passenger })))
    )
    (asserts! (>= (get balance passenger-balance) amount) (err err-insufficient-balance))
    (map-set payments
      { ride-id: ride-id }
      {
        passenger: passenger,
        vehicle-id: vehicle-id,
        amount: amount,
        status: "processed"
      }
    )
    (map-set balances
      { address: passenger }
      { balance: (- (get balance passenger-balance) amount) }
    )
    (ok true)
  )
)

(define-public (add-funds (amount uint))
  (let
    (
      (current-balance (default-to { balance: u0 } (map-get? balances { address: tx-sender })))
    )
    (map-set balances
      { address: tx-sender }
      { balance: (+ (get balance current-balance) amount) }
    )
    (ok true)
  )
)

(define-public (withdraw-funds (amount uint))
  (let
    (
      (current-balance (default-to { balance: u0 } (map-get? balances { address: tx-sender })))
    )
    (asserts! (>= (get balance current-balance) amount) (err err-insufficient-balance))
    (map-set balances
      { address: tx-sender }
      { balance: (- (get balance current-balance) amount) }
    )
    (ok true)
  )
)

(define-read-only (get-balance (address principal))
  (default-to { balance: u0 } (map-get? balances { address: address }))
)

(define-read-only (get-payment (ride-id uint))
  (map-get? payments { ride-id: ride-id })
)

