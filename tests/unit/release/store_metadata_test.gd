extends GdUnitTestSuite
class_name StoreMetadataTest

var _generator: StoreMetadataGenerator

func before_test() -> void:
	_generator = StoreMetadataGenerator.new()

func after_test() -> void:
	_generator.free()

func test_generate_metadata() -> void:
	var metadata := _generator.generate_metadata()
	assert_bool(metadata.has("title")).is_true()
	assert_bool(metadata.has("description")).is_true()
	assert_bool(metadata.has("tags")).is_true()
	assert_bool(metadata.has("version")).is_true()

func test_set_title() -> void:
	_generator.set_title("测试游戏")
	var metadata := _generator.get_metadata()
	assert_str(metadata["title"]).is_equal("测试游戏")

func test_set_description() -> void:
	_generator.set_description("测试描述")
	var metadata := _generator.get_metadata()
	assert_str(metadata["description"]).is_equal("测试描述")

func test_add_tag() -> void:
	_generator.add_tag("new_tag")
	var metadata := _generator.get_metadata()
	assert_bool(metadata["tags"].has("new_tag")).is_true()

func test_add_screenshot() -> void:
	_generator.add_screenshot("screenshot1.png")
	var metadata := _generator.get_metadata()
	assert_bool(metadata["screenshots"].has("screenshot1.png")).is_true()

func test_metadata_generated_signal() -> void:
	var generated_count := 0
	_generator.metadata_generated.connect(func(metadata): generated_count += 1)
	_generator.generate_metadata()
	assert_int(generated_count).is_equal(1)