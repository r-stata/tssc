version 16.0
mata:

void _blncdtree(real matrix tree, real scalar imin, real scalar imax)
{
/*
  Create a balanced tree in rows imin to imax
  of matrix tree, assumed to have at least 2 columns.
  tree contains the tree matrix,
    whose first 2 columns of rows i1 and i2 contain, on exit,
    indices of the left and right daughter row of each row,
    respectively.
  imin contains the index of the minimum row for the tree.
  imax contains the index of the maximum row for the tree.
*! Author: Roger Newson
*! Date: 11 August 2005
*/
real scalar imid, inext
/*
  imid will contain middle (and root) index of tree to be built
  inext will contain neighbouring indices bounding left and right subtrees
*/

imid=trunc((imin+imax)/2)

/*
  Left subtree
*/
if(imid<=imin) {
  tree[imid,1]=0
}
else {
  inext=imid-1
  tree[imid,1]=trunc((imin+inext)/2)
  _blncdtree(tree,imin,inext)
}
/*
  Right subtree
*/
if(imid>=imax) {
  tree[imid,1]=0
}
else {
  inext=imid+1
  tree[imid,2]=trunc((inext+imax)/2)
  _blncdtree(tree,inext,imax)
}

}
end
