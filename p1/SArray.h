/*
 * Project 1 -- SArray reallocating array class (CS 401 and 501)	   	
 ************************************	   	
 *	   	
 * Your job is to finish writing this class to suit the	
 * set of tests provided. Be sure to read IArray.h and AArray.h
 * before you begin. Your SArray class should improve on the
 * efficiency of the CArray class by allocating a buffer twice
 * as large when needed. Look for "TODO"s that you must complete. 
 *
 ******************************************** 
 */	  


#pragma once	   	
	   	
#include "AArray.h"	   	


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


// This is a simple managed array class that will allocate	   	
// new space to grow/shrink its buffer "under the hood"	   	
template<typename T>	  
class SArray	  
    : public AArray<T> 
{ 
private: 
    unsigned capacity;	   	

    // Use a private helper method to resize the current buffer?	   	
    void reallocate(unsigned cap) 
    { 
        // Write a helper method to determine new size?	   	
        // cap = nextsize(cap);	   	
	   	
        // TODO: Reallocate the current buffer to be	   	
        //       at least twice as large
        
        if (this->capacity == 0)
        { 
            this -> capacity++;
        }
        while (cap > this->capacity)
        {
            this->capacity = this->capacity * 2;
        }
        T* m = new T[this->capacity];
        for (unsigned i = 0; i < this->size(); ++i)
        {
            m[i] = this->buffer[i];
        }
        delete [] this->buffer;
        this->buffer = m;
    }
	  
public:	  
    SArray()	  
        : capacity(0)	   	
    { 
    }

    SArray(const AArray<T>& other) 
        : AArray<T>(other), capacity(0) 
    {	  
    }

    virtual ~SArray()	   	
    {
    }

    virtual void insert(const T& elem, unsigned pos)	  
    {	  
        if (pos > this->size())	   	
            throw IArray<T>::ARRAY_OVERFLOW;	   	

        // TODO: write an insert method
        if (this->size()+1 > this->capacity)
        {
            this -> reallocate(this->size()+1);
        }
        
        for (unsigned i = this->size(); i > pos; i--)
        {
            this->buffer[i] = this->buffer[i-1];
        }
        this->buffer[pos] = elem;
        this->count++;
    } 

    virtual void insert(const IArray<T>& other, unsigned pos) 
    {	   	
        if (pos > this->size())
            throw IArray<T>::ARRAY_OVERFLOW; 

        // TODO: write an insert method
        if (this->size()+other.size() > this->capacity)
        {
            this -> reallocate(this->size()+other.size());
        }
        
        for (unsigned i = pos+other.size(); i < this->size()+other.size(); ++i) 
            this->buffer[i] = this->buffer[i-other.size()];	 
        for (unsigned i = pos; i < pos+other.size(); ++i) 
            this->buffer[i] = other[i-pos];	     
        this->count += other.size();
        
    }	  
	
    virtual void remove(unsigned pos, unsigned num = 1)	   	
    {	   	
        // TODO: write a remove method
        if (pos+num > this->size())	
            throw IArray<T>::ARRAY_OVERFLOW; 
        
        if (num == 0) return;	
        for (unsigned i = pos+num; i < this->size(); ++i)	  
            this->buffer[i-num] = this->buffer[i];
        this->count -= num;
        
    }	   	

    virtual void clear()
    { 
        this->AArray<T>::clear(); 
        // TODO: is this complete?
        this->capacity = 0;
    }

    // An iterator for SArray instances	   	
    class Iter	  
        : public AArray<T>::Iter 
    { 
        // TODO: Does more need to be implemented here?	 
    public:
         Iter(IArray<T>& other):AArray<T>::Iter(other) {} 	
    };
};	   	

	  

