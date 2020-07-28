import React from 'react';
import LabeledThing from "./LabeledThing"
import PlainLiteral from "./PlainLiteral";
import TypedLiteral from "./TypedLiteral";
import ControlledURIRef from "./ControlledURIRef";
import Repeatable from "./Repeatable";
import URIRef from "./URIRef";

class DynamicElement extends React.Component {
  constructor(props) {
    super(props);
    this.elements = {
      "LabeledThing": LabeledThing,
      "PlainLiteral": PlainLiteral,
      "TypedLiteral": TypedLiteral,
      "ControlledURIRef": ControlledURIRef,
      "Repeatable": Repeatable,
      "URIRef": URIRef
    };
  }

  render() {
    const Element = this.elements[this.props.type]
    return <Element name={this.props.name} ref={this.props.name} {...this.props}/>;
  }
}

class DynamicElementsList extends React.Component {
  constructor(props) {
    super(props);
    this.listTitle = props.listTitle;
    this.componentsArray = props.componentsArray;
  }

  render() {
    if (this.componentsArray && this.componentsArray.length) {
      return (
        <>
          <h2>{this.listTitle}</h2>

          <dl className="dl-horizontal dl-invert">
          {
            this.componentsArray.map( ([label, type, params], index) => {
              return (
                <div key={`${index}`}>
                  <dt>{label}:</dt>
                  <dd><DynamicElement ref={index} type={type} {...params} /></dd>
                </div>
              )
            })
          }
          </dl>
        </>
      )
    } else {
      return null;
    }
  }
}


class Form extends React.Component {
  constructor(props) {
    super(props);

    // this.authenticityToken = props.authenticityToken;
    // this.contentModel = props.contentModel
    // this.items = props.items
    this.props = props;
    this.requiredComponents = props.required_components;
    this.recommendedComponents = props.recommended_components;
    this.optionalComponents = props.optional_components;
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit() {
    console.log(this.requiredComponents);

    //---------------
    this.csrfToken = $('meta[name=csrf-token]').attr('content');
    alert("Button clicked" + this.csrfToken);

    let body = ""
    body = body + 'utf8=✓';
    body = body + `&authenticity_token=${this.csrfToken}`;
    body = body + '&delete[]=<https://fcrepolocal/fcrepo/rest/pcdm/36/cd/c0/97/36cdc097-1102-4f8f-8178-273c3fc9fa57> <http://purl.org/dc/elements/1.1/date> "1948-08-11"^^<http://id.loc.gov/datatypes/edtf> .';
    body = body + '&insert[]=<https://fcrepolocal/fcrepo/rest/pcdm/36/cd/c0/97/36cdc097-1102-4f8f-8178-273c3fc9fa57> <http://purl.org/dc/elements/1.1/date> "1948-08-12"^^<http://id.loc.gov/datatypes/edtf> .';
    // POST request using fetch with error handling
    const requestOptions = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token':  this.csrfToken
      },
      credentials: 'same-origin',
      body: body
    };
//     fetch('http://localhost:3000/edit/https:%2F%2Ffcrepolocal%2Ffcrepo%2Frest%2Fpcdm%2F36%2Fcd%2Fc0%2F97%2F36cdc097-1102-4f8f-8178-273c3fc9fa57', requestOptions)
//       .then(response => {
//           alert("Foo");
//           const data = response.json();

//           // check for error response
//           if (!response.ok) {
//               // get error message from body or default to response status
//               const error = (data && data.message) || response.status;
//               alert(error);
//               return Promise.reject(error);
//           }

//           alert("Success");
// //          this.setState({ postId: data.id })
//       })
//       .catch(error => {
//           this.setState({ errorMessage: error.toString() });
//           alert(error);
// //          console.error('There was an error!', error);
//       });
  };


  render() {
    const required = this.requiredComponents;

    return (
      <>
      <form onSubmit={this.handleSubmit} data-remote="true">

        <DynamicElementsList ref="required" listTitle="Required Fields" componentsArray={this.requiredComponents} />
        <DynamicElementsList ref="recommended" listTitle="Recommended Fields" componentsArray={this.recommendedComponents} />
        <DynamicElementsList ref="optional" listTitle="Optional Fields" componentsArray={this.optionalComponents} />


        <div className="form-group">
          <input className="btn btn-primary form-control" type="submit" value="Submit" />&nbsp;
          <a className='btn btn-danger form-control' href={this.props.cancel_url}>Cancel</a>
        </div>
      </form>
      </>
    );
  }
}

export default Form;
