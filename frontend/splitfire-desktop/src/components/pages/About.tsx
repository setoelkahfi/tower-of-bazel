import { Col } from "react-bootstrap";
import { FormattedMessage } from "react-intl";

export default function About() {
    return (
            <Col>
                <h1>SplitFire Ai</h1>
                <p>
                    <FormattedMessage id="splitfire.whatIs"
                        defaultMessage="I'm an artificial intelligence software who will split your favorite music to its separate components."
                        description="Explanation message" />
                </p>
            </Col>
    )
}