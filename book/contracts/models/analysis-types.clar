;; contracts/models/analysis-types.clar

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-DUPLICATE (err u409))
(define-constant ERR-EXPIRED (err u410))

;; Analysis Status
(define-constant STATUS-PENDING u1)
(define-constant STATUS-IN-PROGRESS u2)
(define-constant STATUS-COMPLETED u3)
(define-constant STATUS-REJECTED u4)
(define-constant STATUS-EXPIRED u5)

;; Role definitions
(define-constant ROLE-ADMIN u1)
(define-constant ROLE-ANALYST u2)
(define-constant ROLE-REVIEWER u3)
(define-constant ROLE-VIEWER u4)

;; Time constants (in blocks)
(define-constant ANALYSIS-TIMEOUT u144)  ;; ~24 hours in blocks
(define-constant REVIEW-TIMEOUT u72)     ;; ~12 hours in blocks

;; Confidence thresholds
(define-constant MIN-CONFIDENCE u75)
(define-constant MAX-CONFIDENCE u100)
(define-constant HIGH-CONFIDENCE-THRESHOLD u90)
(define-constant LOW-CONFIDENCE-THRESHOLD u80)

;; Analysis types
(define-map analysis-types
    { type-id: uint }
    {
        name: (string-utf8 100),
        min-confidence: uint,
        requires-review: bool,
        timeout: uint
    }
)

;; Response types
(define-response-type analysis-result
    (response
        {
            diagnosis: (string-utf8 100),
            confidence: uint,
            status: uint,
            analyst: principal,
            reviewer: (optional principal),
            timestamp: uint
        }
        uint
    )
)

;; Utility functions
(define-private (is-valid-status (status uint))
    (and 
        (>= status STATUS-PENDING)
        (<= status STATUS-EXPIRED)
    )
)

(define-private (is-valid-role (role uint))
    (and
        (>= role ROLE-ADMIN)
        (<= role ROLE-VIEWER)
    )
)

;; Public getter for analysis type
(define-read-only (get-analysis-type (type-id uint))
    (map-get? analysis-types { type-id: type-id })
)

;; Check if analysis needs review
(define-read-only (requires-review? (type-id uint))
    (match (get-analysis-type type-id)
        analysis-type (get requires-review analysis-type)
        false
    )
)

;; Get minimum confidence for analysis type
(define-read-only (get-min-confidence (type-id uint))
    (match (get-analysis-type type-id)
        analysis-type (get min-confidence analysis-type)
        MIN-CONFIDENCE
    )
)
