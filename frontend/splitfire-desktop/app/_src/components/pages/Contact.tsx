import { Col, Container, Row } from 'react-bootstrap'
import { BsFacebook, BsInstagram, BsTwitter, BsYoutube } from 'react-icons/bs'
import { FormattedMessage } from 'react-intl'

export default function Contact() {
    return (
        <Container>
            <Row>
                <Col>
                    <p>
                        <FormattedMessage id="splitfire.whatIs"
                            defaultMessage="Connect with us."
                            description="Explanation message" />
                    </p>
                    <ul className='list-unstyled'>
                        <li>
                            <BsInstagram /> <a href='https://www.instagram.com/splitfireAI/'>SplitfireAI</a>
                        </li>
                        <li>
                            <BsTwitter /> <a href='https://www.twitter.com/splitfireAI/' >SplitfireAI</a>
                        </li>
                        <li>
                            <BsYoutube /> <a href='https://www.youtube.com/c/SplitFireAI/' >SplitfireAI</a>
                        </li>
                        <li>
                            <BsFacebook /> <a href='https://www.facebook.com/SplitfireAI'>SplitfireAI</a>
                        </li>
                    </ul>
                </Col>
            </Row>
        </Container>
    )
}