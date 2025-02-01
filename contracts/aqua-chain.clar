;; Define data structures
(define-map water-sources
  { source-id: uint }
  {
    location: (string-ascii 64),
    capacity: uint,
    quality-score: uint,
    owner: principal
  }
)

(define-map water-rights
  { holder: principal }
  {
    allocation: uint,
    last-updated: uint
  }
)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-source (err u101))
(define-constant err-insufficient-rights (err u102))

;; Data variables
(define-data-var next-source-id uint u1)
(define-data-var total-sources uint u0)

;; Public functions
(define-public (register-water-source (location (string-ascii 64)) (capacity uint))
  (let
    ((source-id (var-get next-source-id)))
    (if (is-eq tx-sender contract-owner)
      (begin
        (map-set water-sources
          { source-id: source-id }
          {
            location: location,
            capacity: capacity,
            quality-score: u100,
            owner: contract-owner
          }
        )
        (var-set next-source-id (+ source-id u1))
        (var-set total-sources (+ (var-get total-sources) u1))
        (ok source-id))
      err-unauthorized)))

(define-public (transfer-water-rights (new-holder principal) (amount uint))
  (let
    ((current-rights (default-to { allocation: u0, last-updated: u0 }
      (map-get? water-rights { holder: tx-sender }))))
    (if (>= (get allocation current-rights) amount)
      (begin
        (map-set water-rights
          { holder: new-holder }
          {
            allocation: (+ amount (default-to u0 (get allocation (map-get? water-rights { holder: new-holder })))),
            last-updated: block-height
          }
        )
        (map-set water-rights
          { holder: tx-sender }
          {
            allocation: (- (get allocation current-rights) amount),
            last-updated: block-height
          }
        )
        (ok true))
      err-insufficient-rights)))

;; Read only functions
(define-read-only (get-water-source (source-id uint))
  (ok (map-get? water-sources { source-id: source-id })))

(define-read-only (get-water-rights (holder principal))
  (ok (map-get? water-rights { holder: holder })))
