
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

unsigned long bur_heap_size = 0xFFFFF;

#include "strUtil.h"
#include "parson.h"
#include <string.h>
#include <stdbool.h>
#ifdef __cplusplus
	};
#endif
/* TODO: Add your comment here */
plcbit jsonTo6Ddata(unsigned long pBuffer, struct Motion6D_data_typ* Target)
{
	/*TODO: Add your code here*/
	if(pBuffer != 0)
	{
		//const char *text = "[[{\"x\":360,\"y\":60,\"type\":0},{\"x\":360,\"y\":300,\"type\":0},{\"x\":600,\"y\":300,\"type\":0},{\"x\":600,\"y\":420,\"type\":0}]]";
		/*"[[{\"x\":360,\"y\":60,\"type\":0},"
			"{\"x\":360,\"y\":300,\"type\":0},"
			"{\"x\":600,\"y\":300,\"type\":0},"
			"{\"x\":600,\"y\":420,\"type\":0}]]";*/ //(const char *)pBuffer;//"[[{\"x\":360,\"y\":60,\"type\":0},{\"x\":360,\"y\":300,\"type\":0},{\"x\":600,\"y\":300,\"type\":0},{\"x\":600,\"y\":420,\"type\":0}]]";
		char test[2000];
		strcpy(test, (const char *)pBuffer);
		for (int i = 0; test[i] != '\0'; i++) {
			if (test[i] == '\'') {
				test[i] = '"';
			}
		}
		//JSON_Value *root = json_parse_string((const char *)pBuffer);
	

		// Parse JSON string
		JSON_Value *root_value = json_parse_string(test);
		if (!root_value) {
			return false;
		}

		// Get outer array
		JSON_Array *outer_array = json_value_get_array(root_value);
		if (!outer_array) {
			json_value_free(root_value);
			return false;
		}

		size_t outer_count = json_array_get_count(outer_array);

		// Loop through outer array
		for (size_t i = 0; i < outer_count; i++) {
			JSON_Array *inner_array = json_array_get_array(outer_array, i);
			size_t inner_count = json_array_get_count(inner_array);
		
			if(inner_count > 100)
			{
				json_value_free(root_value);
				return false;
			}

			for (size_t j = 0; j < inner_count; j++) {
				JSON_Object *point = json_array_get_object(inner_array, j);
				Target->Points[j].X = (REAL)json_object_get_number(point, "x");
				Target->Points[j].Y = (REAL)json_object_get_number(point, "y");
				Target->Points[j].type = (USINT)json_object_get_number(point, "type");
				//printf("   [%zu][%zu] x=%d, y=%d, type=%d\n", i, j, x, y, type);
			}
		
			Target->count = (USINT)inner_count;
		}

		// Clean up
		json_value_free(root_value);
		return true;
	}
	else
	{
		return false;	
	}
	
}
