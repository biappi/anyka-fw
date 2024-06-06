UNSQUASHFS=/usr/bin/unsquashfs
JEFFERSON=/usr/bin/jefferson

thing:
	docker run -it --rm -v `pwd`:/work -w /work alpine sh -c "apk add make && make inside"

inside: trees.original/mtd4.tree trees.original/mtd5.tree trees.original/mtd6.tree trees.original/mtd7.tree

trees.original:
	mkdir trees.original

trees.original/mtd4.tree: $UNSQUASHFS trees.original
	rm -fr trees.original/mtd4.tree
	unsquashfs -d trees.original/mtd4.tree firmware/mtd4

trees.original/mtd5.tree: $UNSQUASHFS trees.original
	rm -fr trees.original/mtd5.tree
	unsquashfs -d trees.original/mtd5.tree firmware/mtd5

trees.original/mtd6.tree: $JEFFERSON trees.original
	rm -fr trees.original/mtd6.tree
	jefferson -d trees.original/mtd6.tree firmware/mtd6

trees.original/mtd7.tree: $JEFFERSON trees.original
	rm -fr trees.original/mtd7.tree
	jefferson -d trees.original/mtd7.tree firmware/mtd7

$UNSQUASHFS:
	apk add squashfs-tools

$JEFFERSON:
	apk add py3-pip git
	pip install cstruct==1.0 git+https://github.com/svidovich/jefferson-3.git --break-system-packages
