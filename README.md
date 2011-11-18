# ANHTML

ANHTML is an easy-to-use standalone Objective-C HTML parser written with ARC. It does not depend on external libraries such as libxml or NSXMLParser; and still manages to provide very reliable DOM-based parsing.

At the core of ANHTML, the <tt>ANHTMLParser</tt> class tokenizes the XML/HTML document, telling the delegate when it finds text, tags, or escape codes. On top of <tt>ANHTMLParser</tt> is <tt>ANHTMLDocument</tt>, the DOM implementation. <tt>ANHTMLDocument</tt> encapsulates an <tt>ANHTMLParser</tt>, and constructs a DOM as the parser sends it callbacks.

When an <tt>ANHTMLDocument</tt> has been created and is done processing the document, the DOM elements can be traversed and examined through several simple to use methods, allowing for easy, native DOM access. The <tt>ANHTMLDocument</tt> class provides a root element by way of the `rootElement` getter. From there, the `children` attribute can be used to traverse through the root's children. In the event that the given document does not have a single root node, the `rootNode` getter will return a nameless element with more than one sub-nodes.

## A simple parsing example

The <tt>main.m</tt> file included in this repository contains a basic example of how parsing with an <tt>ANHTMLDocument</tt> would be done. Here is a basic walkthrough of this simple example:

    NSData * testData = [@"<html><body><p>This is a basic test</p></body></html>" dataUsingEncoding:NSASCIIStringEncoding];

The purpose of this line is to give ourselves a simple document that we will parse. Next, we create an <tt>ANHTMLDocument</tt> using this data. The `initWithDocumentData:` method automatically parses the given document's data, leaving us with a complete DOM representation by the time the method returns:

    ANHTMLDocument * document = [[ANHTMLDocument alloc] initWithDocumentData:testData];

Since we know that the *&lt;html&gt;* element should be the root element of the document, the `rootElement` method on the `document` variable will return the <tt>ANHTMLElement</tt> for our *&lt;html&gt;* element:

    ANHTMLElement * htmlElem = [document rootElement];

Next, we can get the *&lt;body&gt;* element, which is a child of the *&lt;html&gt;* element:

    ANHTMLElement * body = [[htmlElem childElementsWithName:@"body"] lastObject];

Note that the `childElementsWithName:` method returns an array of children that have a specified element name. In this case, we know that there is only one *&lt;body&gt;* element, so `childElementsWithName:` will return an array with one object. Calling `lastObject` on the array is the shortest way to get the one and only element that is in the array.

Now, finally, we can get all of the text from the *&lt;body&gt;* element and log it to the console:

	NSLog(@"%@", [body stringValue]);
