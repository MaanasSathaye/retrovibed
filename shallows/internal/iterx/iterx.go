package iterx

import "iter"

func FromChannel[T any](ch <-chan T) iter.Seq[T] {
	return func(yield func(T) bool) {
		for val := range ch {
			if !yield(val) {
				return // Consumer stopped iterating
			}
		}
	}
}

func From[T any](items ...T) iter.Seq[T] {
	return func(yield func(T) bool) {
		for _, val := range items {
			if !yield(val) {
				return // Consumer stopped iterating
			}
		}
	}
}
