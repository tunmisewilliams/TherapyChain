;; TherapyChain - Mental health therapy session tracking and recognition platform
;; Version: 1.0.0

(define-data-var program-coordinator principal tx-sender)
(define-data-var total-therapy-hours uint u0)
(define-data-var recognition-multiplier uint u25) ;; recognition points per hour
(define-data-var last-recognition-cycle uint u0)

(define-map therapist-contributions principal uint)
(define-map therapist-modalities principal (string-utf8 64))
(define-map modality-approvals (string-utf8 64) bool)

;; Error codes
(define-constant err-unauthorized-coordinator (err u1200))
(define-constant err-coordinator-already-exists (err u1201))
(define-constant err-invalid-hours (err u1202))
(define-constant err-no-recognition-due (err u1203))
(define-constant err-no-contributions (err u1204))
(define-constant err-invalid-modality (err u1205))
(define-constant err-modality-not-approved (err u1206))

;; Verify coordinator authorization
(define-private (is-program-coordinator (caller principal))
  (begin
    (asserts! (is-eq caller (var-get program-coordinator)) err-unauthorized-coordinator)
    (ok true)))

;; Initialize therapy tracking program
(define-public (launch-therapy-program (coordinator principal))
  (begin
    (asserts! (is-none (map-get? therapist-contributions coordinator)) err-coordinator-already-exists)
    (var-set program-coordinator coordinator)
    (ok "TherapyChain program launched successfully")))

;; Approve modality for therapy tracking
(define-public (approve-modality (modality-name (string-utf8 64)))
  (begin
    (try! (is-program-coordinator tx-sender))
    (asserts! (> (len modality-name) u0) err-invalid-modality)
    (map-set modality-approvals modality-name true)
    (ok "Modality approved for therapy tracking")))

;; Register therapy hours
(define-public (log-therapy-hours (hours uint) (modality (string-utf8 64)))
  (begin
    (asserts! (> hours u0) err-invalid-hours)
    (asserts! (default-to false (map-get? modality-approvals modality)) err-modality-not-approved)
    
    (let ((current-hours (default-to u0 (map-get? therapist-contributions tx-sender))))
      (map-set therapist-contributions tx-sender (+ current-hours hours))
      (map-set therapist-modalities tx-sender modality)
      (var-set total-therapy-hours (+ (var-get total-therapy-hours) hours))
      (ok (+ current-hours hours)))))

;; Calculate recognition points
(define-public (calculate-recognition-points)
  (begin
    (try! (is-program-coordinator tx-sender))
    (let ((current-cycle (+ (var-get last-recognition-cycle) u1))
          (total-hours (var-get total-therapy-hours)))
      (asserts! (> total-hours (var-get last-recognition-cycle)) err-no-recognition-due)
      
      (let ((new-recognition-points (* (var-get recognition-multiplier) total-hours)))
        (var-set last-recognition-cycle current-cycle)
        (ok new-recognition-points)))))

;; Claim therapy recognition rewards
(define-public (claim-therapy-recognition)
  (begin
    (let ((therapist-hours (default-to u0 (map-get? therapist-contributions tx-sender))))
      (asserts! (> therapist-hours u0) err-no-contributions)
      
      (let ((total-hours (var-get total-therapy-hours))
            (recognition-points (* (var-get recognition-multiplier) therapist-hours))
            (contribution-percentage (/ (* therapist-hours u100000) total-hours)))
        
        (let ((final-recognition (/ (* contribution-percentage recognition-points) u100000)))
          (map-delete therapist-contributions tx-sender)
          (map-delete therapist-modalities tx-sender)
          (var-set total-therapy-hours (- (var-get total-therapy-hours) therapist-hours))
          (ok (+ therapist-hours final-recognition)))))))

;; Read-only functions
(define-read-only (get-therapy-hours (therapist principal))
  (default-to u0 (map-get? therapist-contributions therapist)))

(define-read-only (get-therapist-modality (therapist principal))
  (map-get? therapist-modalities therapist))

(define-read-only (get-total-therapy-hours)
  (var-get total-therapy-hours))

(define-read-only (is-modality-approved (modality-name (string-utf8 64)))
  (default-to false (map-get? modality-approvals modality-name)))

(define-read-only (get-program-stats)
  {
    coordinator: (var-get program-coordinator),
    total-hours: (var-get total-therapy-hours),
    recognition-multiplier: (var-get recognition-multiplier)
  })