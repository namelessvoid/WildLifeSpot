# Command and Query Handlers

To decouple UI and business logic, `Commands` and `Queries` are used in the UI to change and to retrieve domain state.

This page describes how commands and queries are dispatched, how handlers have to be implemented and how handlers are discovered automatically by the dispatching component.

## CommandQueryDispatcher global class

The `CommandQueryDispatcher` is a global class that routes the commands and queries to the appropriate handler (cf. "mediator pattern"). To dispatch commands and queries, pass them to the `CommandQueryDispatcher.handle(...)` method.

## Command / Query Handlers

Handlers classes have to provide two methods:

- `can_handle(dispatchable: Variant) -> bool` (`public bool CanHandle(Variant dispatchable)` in C#) 
- `handle(dispatchable: Variant) -> Variant` (`public Variant Handle(Variant dispatchable)` in C#)

For GDScript based handlers, implement the `CommandQueryHandler` class.

The `can_handle` method is used by the `CommandQueryDispatcher` to find an appropriate handler. Therefore, the method should return true if the handler can handle the dispatchable, otherwise false. If no handler or more than one handler was found, that claim to handle the dispatchable, an error is logged. Therefore, there has to be exactly one handler for each dispatchable.

The `handle` method is invoked on the matching handler and the dispatchable is passed to that method.

## Handler discover

The `CommandQueryDispatcher` uses the group `command_query_handler` to auto-discover command and query handlers. If you want to register a handler, make sure that the handler has this group assigned before `_ready()` is processed.

For GD-Script based handlers that implement `CommandQueryHandler`, the gorup is automatically assigned on `_enter_tree()`.
