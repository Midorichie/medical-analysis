;; contracts/medical-analysis.clar
;; Medical Image Analysis Smart Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-image (err u101))
(define-constant err-invalid-diagnosis (err u102))
(define-constant err-invalid-confidence (err u103))
(define-constant err-invalid-minimum (err u104))

;; Maximum length for diagnosis string
(define-constant max-diagnosis-length u100)

;; Data Variables
(define-data-var minimum-confidence uint u75)  ;; Minimum confidence score (75%)
(define-data-var maximum-confidence uint u100) ;; Maximum confidence score (100%)

;; Data Maps
(define-map image-analysis
    { image-hash: (buff 32) }
    {
        diagnosis: (string-utf8 100),
        confidence: uint,
        timestamp: uint,
        analyst: principal
    }
)

;; Private Functions
(define-private (validate-confidence (confidence uint))
    (and 
        (>= confidence (var-get minimum-confidence))
        (<= confidence (var-get maximum-confidence))
    )
)

(define-private (validate-diagnosis (diagnosis (string-utf8 100)))
    (> (len diagnosis) u0)
)

(define-private (validate-image-hash (image-hash (buff 32)))
    (is-eq (len image-hash) u32)
)

;; Public Functions
(define-public (submit-analysis (image-hash (buff 32)) 
                              (diagnosis (string-utf8 100)) 
                              (confidence uint))
    (begin
        ;; Validate input data
        (asserts! (validate-image-hash image-hash) err-invalid-image)
        (asserts! (validate-diagnosis diagnosis) err-invalid-diagnosis)
        (asserts! (validate-confidence confidence) err-invalid-confidence)
        
        (ok (map-set image-analysis
            { image-hash: image-hash }
            {
                diagnosis: diagnosis,
                confidence: confidence,
                timestamp: block-height,
                analyst: tx-sender
            }
        ))
    )
)

;; Read-Only Functions
(define-read-only (get-analysis (image-hash (buff 32)))
    (map-get? image-analysis { image-hash: image-hash })
)

;; Admin Functions
(define-public (set-minimum-confidence (new-minimum uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= new-minimum (var-get maximum-confidence)) err-invalid-minimum)
        (asserts! (> new-minimum u0) err-invalid-minimum)
        (ok (var-set minimum-confidence new-minimum))
    )
)

;; Add this new function to validate existing analysis
(define-read-only (is-valid-analysis (image-hash (buff 32)))
    (match (get-analysis image-hash)
        analysis (and 
            (validate-diagnosis (get diagnosis analysis))
            (validate-confidence (get confidence analysis))
        )
        false
    )
)
