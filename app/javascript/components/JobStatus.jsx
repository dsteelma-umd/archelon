import React from "react"
import PropTypes, { string } from "prop-types"

// const N3 = require('n3');
// const { DataFactory } = N3;
// const { namedNode, literal, defaultGraph } = DataFactory;

/**
 * Component displaying the current status of a job.
 *
 *  Sample Rails view usage:
 *
 * ```
 * <%= react_component(
 *   :JobStatus,
 *   {
 *     status: 'pending',
 *     progress: 50
 *     job_id: 2
 *   }
 * ) %>
 * ```
 *
 * When used in a form, this will submit the array `example[title][]`
 * with a single value, `{"@value": "Lorem ipsum", "@language": "en"}`.
 */
class JobStatus extends React.Component {
  constructor(props) {
    super(props);

    this.job_id = props.job_id
    this.status = props.status
    this.progress = props.progress
    this.download_file_size = props.download_file_size
    this.download_url = props.download_url
    this.job_done = props.job_done
  };

  // handleTextChange(event) {
  //   let newValue = event.target.value;
  //   let valueChanged = (newValue !== this.initialValue);
  //   this.setState(function(state, props) {
  //     if (props.onChange) {
  //       props.onChange(valueChanged || state.languageChanged);
  //     }
  //     return {
  //       value: newValue,
  //       valueChanged: valueChanged,
  //     };
  //   });
  // };

  // handleLanguageChange(event) {
  //   let newLanguage = event.target.value;
  //   let languageChanged = (newLanguage !== this.initialLanguage)
  //   this.setState(function(state, props) {
  //     if (props.onChange) {
  //       props.onChange(languageChanged || state.valueChanged);
  //     }
  //     return {
  //       language: newLanguage,
  //       languageChanged: languageChanged,
  //     };
  //   });
  // }

  // getStatement(value, language) {
  //   const writer = new N3.Writer({format: 'N-Triples'});

  //   let literalValue = literal(value, language || undefined)

  //   if (this.isValueUriRef) {
  //     // If value was originally a URIRef, wrap in < >, instead of quotes.
  //     literalValue = { id: `<${value}>` };
  //   }

  //   return writer.quadToString(
  //       namedNode(this.props.subjectURI),
  //       namedNode(this.props.predicateURI),
  //       literalValue,
  //       defaultGraph(),
  //   );
  // }

  // componentWillUnmount() {
  //   if (this.props.notifyContainer && !this.props.value.isNew) {
  //     this.props.notifyContainer(this.initialStatement)
  //   }
  // }

  render () {
    let status = 'pending'
    let job_id = '5'
    let progress = 50
    // let statement = this.getStatement(this.state.value, this.state.language);
    // let valueIsUnchanged = !(this.state.valueChanged || this.state.languageChanged)


    return (
      <React.Fragment>
        <div>{this.job_id} {this.status} {this.progress} {this.download_file_size} {this.download_url} {this.job_done}</div>
      </React.Fragment>
    );
  }
}


JobStatus.propTypes = {
  status: PropTypes.string,
  progress: PropTypes.number,
  job_id: PropTypes.number,
  download_file_size: string,
  download_url: string
}

JobStatus.defaultProps = {
  status: 'Pending',
  progress: 0
}

export default JobStatus;
