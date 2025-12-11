# Validatable Controls

The `ValidatableControls` sub-classes are controls that provide built-in validation.

The user of the controls have to supply a validation callback to the `validator` property.

Contract for implementors of `ValidatableControls`:

- The controls should expose the same interface as the wrapped control. E.g. a `ValidatableLineEdit` should have a `text` and `placeholder_text` property.
- When the value of the internal edit changed, call `validate()` before emitting any `*_changed` signals.