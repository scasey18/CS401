/*	  
* Project 0 -- Part 1: AssocList.h (required for everyone) 
********************************************
*
* Your task is to complete the following AssocList class so that all
* methods behave as expected and the class satisfies the IMap interface.	   	
* The class is templated so that it may be used for various key (K) and	  
* value (V) types. The structure stores keys themselves, and pointers	
* to values. This is so the 'lookup' method may return a null pointer 
* when a key cannot be found. 'remove' returns true if a key-value is	   	
* found and removed and false if no change was made. 'add' replaces	  
* an existing value for the input key or adds a new key-value pair.	   	
* The ctor sets up an empty association list, the dtor properly cleans up
* the datastructure (freeing used memory) and 'size' reports the # of keys.
* (See IMap.h for more details.) There are various correct ways to complete	   	
* the assignment, ask if you have questions. Search for "TODO" in this file. 
* 
************************************	  
*/ 


#pragma once	   	

#include "IMap.h"



/************************************	
* Honor pledge (please write your name.)
*	  
* I **Samuel Casey** have completed this code myself, without	  
* unauthorized assistance, and have followed the academic honor code.
* 
* Edit the code below to complete your solution.	  
*	   	
********************************************	
*/	  


template <typename K, typename V>	   	
class AssocList
: public IMap<K,V>	  
{	  
	// A private struct useful for links of the list	  
	struct Link	  
	{	
		K k;	  
		V* v; 
		Link* next;	  

		Link(const K _k, V* const _v, Link* const _next)	
		: k(_k), v(_v), next(_next)
		{	   	
		}	  
	}; 

private: 
	// A counter for the total number of keys in the association list 
	unsigned count;	  

	// A pointer to the root node	  
	Link* root; 

public:	   	
	AssocList() 
	: count(0), root(0)	  
	{	
	}	   	

	~AssocList()	   	
	{
		while (root)	  
		remove(root->k);	   	
	}

	// A method for mutably extending the map with a new key-value association	   	
	void add(const K& key, V* const val)
	{	
		// TODO: write add method
		Link* node = root;
		Link* prev;

		while (node && node->k != key)
		{	
			prev = node;
			node = node->next;
		}
		
		if (node)
		{
			node->v = val;
		}
		else
		{
			node = new Link(key,val,0);
			
			if (root == 0x0)
			{
				root = node;
			}
			else 
			{
				prev->next = node;
			}
		}
	}

	// A method for mutably deleting a key (and its value) from the current map 
	bool remove(const K& key)	   	
	{	  
		// TODO: write remove method
		Link* node = root;
		Link* prev = 0;
		while (node && node->k != key)
		{
			prev = node;
			node = node->next;
		}
		
		if (node && prev != 0x0)
		{
			prev->next = node->next;
			return true;
		}
		else if(node)
		{
			root = root ->next;
			return true;
		}
		else
		{
			return false;
		}
		
	}	  

	// A method for looking up the value associated with a given key	   	
	V* lookup(const K& key) const 
	{	   	
		// Start at the root	   	
		Link* node = root;	   	

		// Follow the linked list until reaching null	   	
		// or a node where the key matches	
		while (node && node->k != key)
		{			
			node = node->next;	   	
		}

		// Return the associated value, or null	  
		if (node)
		{
			return node->v;	
		}
		else
		{			
			return 0;
		}
	}	   	

	// A method for reporting the current number of keys in the map	  
	unsigned size() const 
	{	   	
		// TODO: write size method
		int count = 0;
		Link* node = root;
		while (node && node->k){
			count++;
			node = node->next;
		}
		return count;
	}
}; 