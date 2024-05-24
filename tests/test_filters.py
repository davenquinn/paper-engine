from panflute import convert_text, Cite


def test_filters():
    test = "@fig:some-fig|b"
    test1 = convert_text(test)
    elements = test1[0].content
    assert len(elements) == 1
    citation = elements[0]
    assert isinstance(citation, Cite)
