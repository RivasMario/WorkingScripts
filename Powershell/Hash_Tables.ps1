<#
HashTables:

A hash table is a compact data structure that stores one or more key/value pairs.
Example: A series of IP addresses and computer names
#>

# Creating a Hashtable
$hash = @{}

#########################
# Adding to a hashtable #
# Hash tables are not expected to be in order, will pull randomly

$hash.Add("Person", "John")
$hash.Add("Email", "John@john.com")
$hash.Add("Pet", "Cat")
$hash.Add("Surname", "Smith")
$hash

# Removing key from hashtable
$hash.Remove("Surname")

#Pre-populating hashtables
$details = @{
    Person = "Mike"
    Email = "Mike@Mike.com"
    Pet = "Dog"
}
$details

# Adding key thgat already exists throws error
$details.Add("Pet", "Snake")

###################
# Accessing Items #

#Gets name of Key wanted
$details["Pet"] #explicity tells this is a hash table
$details.Pet

