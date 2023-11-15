(load-file "libEMT.dylib")
(emt--do-split-helper "你好我好大家好")
(emt--tokens-range-helper "你好我好大家好")
;; [(0 . 1) (1 . 2) (2 . 3) (3 . 4) (4 . 6) (6 . 7)]
(emt--word-at-point-or-forward-helper "What the fuck is this" 5)
(emt--token-range-at-index-helper "What the fuck is this" 5)
;; (5 . 8)
