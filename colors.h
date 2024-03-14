/* Terminal colors (16 first used in escape sequence) */
static const char *colorname[] = {
	/* 8 normal colors */
	"#161510",
	"#a32810",
	"#727a18",
	"#a37720",
	"#3d6266",
	"#7a4955",
	"#557a55",
	"#8e8463",

	/* 8 bright colors */
	"#4c4635",
	"#cc3214",
	"#8e991e",
	"#cc9528",
	"#4c7b7f",
	"#995b6b",
	"#6b996b",
	"#ccbc8e",

	[255] = 0,

	/* more colors can be added after 255 to use with DefaultXX */
	"#cccccc",
	"#555555",
};
