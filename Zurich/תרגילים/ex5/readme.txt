shirley.m.h
206145245

batsheva77
205505001

##############################################

Part 4 / Reractions / intersectPlaneCheckered
- We first determine which plane we are on, then choose the row and column of the point accordingly.
- We decide the color for each point by checking if the fraction part of its row and column coordinates is smaller than 0.5.
- Then, each column and row has a color-value (0 or 1). If the row_color is 0 then the column_color stays as it was.
   Otherwise (row_color=1) we flip the value of the column_color.

At first we wrote this logic with 'if' statements, then we realised we have this logic table:

	row   |   col   |   final_color
	 0    |    0    |     0
	 1    |    0    |     1
	 0    |    1    |     1
	 1    |    1    |     0

and that our final_color can be recieved with a single Xor operator.

All other computations are similar to intersectPlane (but we didn't use it by calling it because we calculate the bestHit.position during the process and then use it to detemine the color/material of that point).

##############################################

Part 5 / Cylinders / intersectCylinderY

- We first draw the top and buttom of the cylinder using intersectCircle().
- As we learned from other algorithms of finding intersections, we find the intersection of the cylinder and the ray by using their implicit representation and find the minimal t such that f(r(t))=0.
- By checking if the discriminant (D=B^2-4AC) is smaller or bigger than zero, or equals to it, we get the number of solutions (0, 1 or 2).
- If we have two solutions, we choose the minimal one (that is non-negative).
- Finally, the cylinder equation of the implicit representation (that was given in the PDF) was for an infinite cylinder.
   So, we had to make sure that the intersection point we found is within the finite cylinder (that is limited by given height h).

##############################################

Links:
https://www.geeksforgeeks.org/bitwise-operators-in-c-cpp/
https://math.stackexchange.com/questions/1184038/what-is-the-equation-of-a-general-circle-in-3-d-space
