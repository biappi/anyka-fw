UNSQUASHFS=/usr/bin/unsquashfs
JEFFERSON=/usr/bin/jefferson

thing:
	docker run -it --rm -v `pwd`:/work -w /work alpine sh -c "apk add make && make inside"

inside: trees/mtd4.tree trees/mtd5.tree trees/mtd6.tree trees/mtd7.tree

trees:
	mkdir trees

trees/mtd4.tree: $UNSQUASHFS trees
	rm -fr trees/mtd4.tree
	unsquashfs -d trees/mtd4.tree firmware/mtd4

trees/mtd5.tree: $UNSQUASHFS trees
	rm -fr trees/mtd5.tree
	unsquashfs -d trees/mtd5.tree firmware/mtd5

trees/mtd6.tree: $JEFFERSON trees
	rm -fr trees/mtd6.tree
	jefferson -d trees/mtd6.tree firmware/mtd6

trees/mtd7.tree: $JEFFERSON trees
	rm -fr trees/mtd7.tree
	jefferson -d trees/mtd7.tree firmware/mtd7

$UNSQUASHFS:
	apk add squashfs-tools

$JEFFERSON:
	apk add py3-pip git
	pip install cstruct==1.0 git+https://github.com/svidovich/jefferson-3.git --break-system-packages
