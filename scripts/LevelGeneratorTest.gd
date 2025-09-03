# GdUnit generated TestSuite
class_name LevelGeneratorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source: String = 'res://scripts/LevelGenerator.gd'
const LevelGenerator = preload("res://scripts/LevelGenerator.gd")

var level_generator: Node


func before_test():
    level_generator = auto_free(LevelGenerator.new())


func test_initialization():
    assert_that(level_generator).is_not_null()
    assert_that(level_generator).is_inheriting(Node3D)
