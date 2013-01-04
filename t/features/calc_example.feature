#
# @author Johan Sydseter, <johan.sydseter@startsiden.no>
#
Feature: This is an example of a feature

    Scenario: Here is the description of a scenario
        When the first operand is "<operand_one>"
        And the operator "<operator>" is beeing used
        And the second operand is "<operand_two>"
        Then the total should be "<sum>"
        Examples:
            | operand_one | operator | operand_two | sum |
            | 2           | +        | 2           | 4   |
